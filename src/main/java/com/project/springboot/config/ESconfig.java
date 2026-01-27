package com.project.springboot.config;

import org.apache.http.HttpHost;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestHighLevelClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

@Configuration
public class ESconfig {
	@Bean
	public RestHighLevelClient client() {
		return new RestHighLevelClient(
				RestClient.builder(new HttpHost("localhost",9200,"http"))
		);		
	}
	
	@Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
