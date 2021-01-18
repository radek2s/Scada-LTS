package org.regsoft.controller;

import org.regsoft.model.User;
import org.regsoft.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(path = "/api/user")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/")
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @GetMapping("?id={id}")
    public ResponseEntity<User> getUserById(@PathVariable(value = "id") Long userId) {
        User user = userRepository.findById(userId).orElseThrow(null);
        return ResponseEntity.ok().body(user);
    }

    @PostMapping("/")
    public User createUser(@RequestBody User user) {
        System.out.println("Received user data");
        return userRepository.save(user);
    }



}
