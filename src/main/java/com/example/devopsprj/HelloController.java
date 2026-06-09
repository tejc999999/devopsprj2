package com.example.devopsprj;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

  @GetMapping("/")
  public String hello() {
    return "Hello World 2026/06/09-3";
  }

  @GetMapping("/hello")
  public String helloWithName() {
    return "Hello, Spring Boot!";
  }
}