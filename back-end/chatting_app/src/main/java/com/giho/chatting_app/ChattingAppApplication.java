package com.giho.chatting_app;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ChattingAppApplication {

	public static void main(String[] args) {

		// .env 파일 로드
		Dotenv dotenv = Dotenv.configure().load();

		// MYSQL_PASSWORD를 환경 변수로 설정
		System.setProperty("MONGODB_URL", dotenv.get("MONGODB_URL"));
		System.setProperty("MYSQL_PASSWORD", dotenv.get("MYSQL_PASSWORD"));
		System.setProperty("JWT_SECRET_KEY", dotenv.get("JWT_SECRET_KEY"));
		System.setProperty("JWT_ISSUER", dotenv.get("JWT_ISSUER"));
		System.setProperty("ACCESS_TOKEN_EXP", dotenv.get("ACCESS_TOKEN_EXP"));
		System.setProperty("REFRESH_TOKEN_EXP", dotenv.get("REFRESH_TOKEN_EXP"));
		System.setProperty("PROFILE_IMAGE_PATH", dotenv.get("PROFILE_IMAGE_PATH"));

		SpringApplication.run(ChattingAppApplication.class, args);
	}

}
