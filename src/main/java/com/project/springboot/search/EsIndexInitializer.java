package com.project.springboot.search;

import jakarta.annotation.PostConstruct;

import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.client.indices.CreateIndexRequest;
import org.elasticsearch.client.indices.GetIndexRequest;
import org.elasticsearch.common.settings.Settings;
import org.elasticsearch.common.xcontent.XContentType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * ES 인덱스가 없으면 앱 시작 시 자동 생성합니다.
 * - 2글자만 입력해도 검색이 되도록 edge_ngram(min=2) 사용
 * - max_gram을 크게 쓰면 ES 기본 제한(index.max_ngram_diff)에 걸리므로, 설정을 같이 올려줍니다.
 */
@Component
public class EsIndexInitializer {

    public static final String INDEX_NAME = "music_index";

    @Autowired
    private RestHighLevelClient client;

    @PostConstruct
    public void init() {
        try {
            // 1) 인덱스 존재 여부 확인
            GetIndexRequest existsReq = new GetIndexRequest(INDEX_NAME);
            boolean exists = client.indices().exists(existsReq, RequestOptions.DEFAULT);
            if (exists) {
                return;
            }

            // 2) 인덱스 생성 (analyzer + mapping)
            CreateIndexRequest req = new CreateIndexRequest(INDEX_NAME);

            // edge_ngram(min=2,max=20) => diff=18 이므로 index.max_ngram_diff를 18로 설정
            req.settings(Settings.builder()
                    .put("index.number_of_shards", 1)
                    .put("index.number_of_replicas", 0)
                    .put("index.max_ngram_diff", 18)
            );

            // 분석기: index 시에는 edge_ngram, search 시에는 standard
            String mappingJson = "{\n" +
                    "  \"settings\": {\n" +
                    "    \"analysis\": {\n" +
                    "      \"filter\": {\n" +
                    "        \"edge_ngram_2_20\": {\n" +
                    "          \"type\": \"edge_ngram\",\n" +
                    "          \"min_gram\": 2,\n" +
                    "          \"max_gram\": 20\n" +
                    "        }\n" +
                    "      },\n" +
                    "      \"analyzer\": {\n" +
                    "        \"ngram_analyzer\": {\n" +
                    "          \"type\": \"custom\",\n" +
                    "          \"tokenizer\": \"standard\",\n" +
                    "          \"filter\": [\"lowercase\", \"edge_ngram_2_20\"]\n" +
                    "        },\n" +
                    "        \"search_analyzer\": {\n" +
                    "          \"type\": \"custom\",\n" +
                    "          \"tokenizer\": \"standard\",\n" +
                    "          \"filter\": [\"lowercase\"]\n" +
                    "        }\n" +
                    "      }\n" +
                    "    }\n" +
                    "  },\n" +
                    "  \"mappings\": {\n" +
                    "    \"properties\": {\n" +
                    "      \"m_no\": { \"type\": \"integer\" },\n" +
                    "      \"m_title\": { \"type\": \"text\", \"analyzer\": \"ngram_analyzer\", \"search_analyzer\": \"search_analyzer\",\n" +
                    "        \"fields\": { \"keyword\": { \"type\": \"keyword\" } }\n" +
                    "      },\n" +
                    "      \"a_name\": { \"type\": \"text\", \"analyzer\": \"ngram_analyzer\", \"search_analyzer\": \"search_analyzer\",\n" +
                    "        \"fields\": { \"keyword\": { \"type\": \"keyword\" } }\n" +
                    "      },\n" +
                    "      \"b_title\": { \"type\": \"text\", \"analyzer\": \"ngram_analyzer\", \"search_analyzer\": \"search_analyzer\" },\n" +
                    "      \"b_image\": { \"type\": \"keyword\" },\n" +
                    "      \"m_preview_url\": { \"type\": \"keyword\" },\n" +
                    "      \"m_youtube_id\": { \"type\": \"keyword\" },\n" +
                    "      \"lyrics_text\": { \"type\": \"text\", \"analyzer\": \"ngram_analyzer\", \"search_analyzer\": \"search_analyzer\" }\n" +
                    "    }\n" +
                    "  }\n" +
                    "}";

            // CreateIndexRequest에는 settings/mappings를 따로 넣을 수도 있지만,
            // 여기서는 JSON 하나로 넣어서 실수 줄이기.
            req.source(mappingJson, XContentType.JSON);

            client.indices().create(req, RequestOptions.DEFAULT);
            System.out.println("[ES] index created: " + INDEX_NAME);
        } catch (Exception e) {
            System.err.println("[ES] index init failed: " + e.getMessage());
        }
    }
}
