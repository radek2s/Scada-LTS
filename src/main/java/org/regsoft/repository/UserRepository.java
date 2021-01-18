package org.regsoft.repository;

import org.regsoft.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository  extends  JpaRepository<User, Long>{ }
