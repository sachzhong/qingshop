package cn.iocoder.yudao.module.aiops.framework.llm;

import cn.hutool.core.util.StrUtil;
import cn.hutool.http.HttpRequest;
import cn.hutool.http.HttpResponse;
import cn.iocoder.yudao.framework.common.util.json.JsonUtils;
import cn.iocoder.yudao.module.aiops.dal.dataobject.AiOpsConfigDO;
import com.fasterxml.jackson.databind.JsonNode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * 极简 OpenAI 兼容客户端（chat/completions、images/generations）。
 *
 * 没有复用 yudao-module-ai：该模块依赖 Spring AI 全家桶、体积大，且在 yudao-cloud 中默认未启用；
 * AI 运营只需要“发一段提示词、拿回一段 JSON”，用 hutool HTTP 足够。
 */
@Component
@Slf4j
public class AiOpsLlmClient {

    private static final int TIMEOUT_MS = 120_000;

    public static String resolveKey(String envName) {
        if (StrUtil.isBlank(envName)) {
            return null;
        }
        String v = System.getenv(envName);
        return StrUtil.isBlank(v) ? System.getProperty(envName) : v;
    }

    /** 调用大模型，要求返回 JSON 对象；返回解析后的 JsonNode */
    public JsonNode chatJson(AiOpsConfigDO config, String system, String user) {
        String key = resolveKey(config.getLlmKeyEnv());
        if (StrUtil.isBlank(config.getLlmBaseUrl()) || StrUtil.isBlank(key)) {
            throw new IllegalStateException("大模型未配置：baseUrl 为空或环境变量 " + config.getLlmKeyEnv() + " 未设置");
        }
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("model", config.getLlmModel());
        body.put("temperature", 0.3);
        body.put("max_tokens", 4096);
        body.put("response_format", Collections.singletonMap("type", "json_object"));
        List<Map<String, String>> messages = new ArrayList<>();
        messages.add(msg("system", system));
        messages.add(msg("user", user));
        body.put("messages", messages);
        String url = StrUtil.removeSuffix(config.getLlmBaseUrl(), "/") + "/chat/completions";
        long start = System.currentTimeMillis();
        try (HttpResponse resp = HttpRequest.post(url).bearerAuth(key).timeout(TIMEOUT_MS)
                .body(JsonUtils.toJsonString(body), "application/json").execute()) {
            String text = resp.body();
            if (!resp.isOk()) {
                throw new IllegalStateException("大模型返回 HTTP " + resp.getStatus() + ": " + StrUtil.subPre(text, 300));
            }
            JsonNode root = JsonUtils.parseTree(text);
            String content = root.path("choices").path(0).path("message").path("content").asText("");
            log.info("[chatJson][model={} 耗时={}ms tokens={}]", config.getLlmModel(), System.currentTimeMillis() - start,
                    root.path("usage").path("total_tokens").asInt());
            return JsonUtils.parseTree(extractJson(content));
        }
    }

    /** 图片生成：返回图片二进制；未配置返回 null */
    public byte[] generateImage(AiOpsConfigDO config, String prompt) {
        String key = resolveKey(config.getImageKeyEnv());
        if (StrUtil.isBlank(config.getImageBaseUrl()) || StrUtil.isBlank(key)) {
            return null;
        }
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("model", config.getImageModel());
        body.put("prompt", prompt);
        body.put("n", 1);
        body.put("size", "1024x1024");
        body.put("response_format", "b64_json");
        String url = StrUtil.removeSuffix(config.getImageBaseUrl(), "/") + "/images/generations";
        try (HttpResponse resp = HttpRequest.post(url).bearerAuth(key).timeout(TIMEOUT_MS)
                .body(JsonUtils.toJsonString(body), "application/json").execute()) {
            if (!resp.isOk()) {
                throw new IllegalStateException("图片接口返回 HTTP " + resp.getStatus() + ": " + StrUtil.subPre(resp.body(), 300));
            }
            JsonNode data = JsonUtils.parseTree(resp.body()).path("data").path(0);
            if (data.hasNonNull("b64_json")) {
                return Base64.getDecoder().decode(data.get("b64_json").asText());
            }
            if (data.hasNonNull("url")) {
                return HttpRequest.get(data.get("url").asText()).timeout(TIMEOUT_MS).execute().bodyBytes();
            }
            throw new IllegalStateException("图片接口没有返回 b64_json / url");
        }
    }

    /** 兼容模型把 JSON 包在 ```json 代码块里的情况 */
    static String extractJson(String content) {
        String s = StrUtil.trim(content);
        int l = s.indexOf('{');
        int r = s.lastIndexOf('}');
        if (l < 0 || r <= l) {
            throw new IllegalStateException("大模型没有返回 JSON：" + StrUtil.subPre(s, 200));
        }
        return s.substring(l, r + 1);
    }

    private static Map<String, String> msg(String role, String content) {
        Map<String, String> m = new HashMap<>();
        m.put("role", role);
        m.put("content", content);
        return m;
    }

}
