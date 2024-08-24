package com.gb.et.models;

import jakarta.persistence.*;

import java.util.Set;

@Entity
public class Organization {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @OneToMany(mappedBy = "organization")
    private Set<User> users;
}
