Feature: Basic Synchronization
  As a developer using SpreadGem
  I want to synchronize objects across multiple instances
  So that all clients have consistent data

  Background:
    Given a SpreadJS server is running

  Scenario: Synchronize simple values across instances
    Given two Ruby clients are connected
    When client 1 sets a value
    And the clients synchronize
    Then client 2 should receive the update

  Scenario: Multiple clients stay in sync
    Given a client named "alice" is connected
    And a client named "bob" is connected
    And a client named "charlie" is connected
    When "alice" sets "username" to "alice_user"
    And "bob" sets "status" to "online"
    Then "alice" should see "status" equals "online"
    And "bob" should see "username" equals "alice_user"
    And "charlie" should see "username" equals "alice_user"
    And "charlie" should see "status" equals "online"

  Scenario: Update existing values
    Given a client named "client1" is connected
    And a client named "client2" is connected
    When "client1" sets "counter" to "1"
    And "client1" sets "counter" to "2"
    And "client1" sets "counter" to "3"
    Then "client2" should see "counter" equals "3"

  Scenario: Delete synchronized values
    Given a client named "client1" is connected
    And a client named "client2" is connected
    When "client1" sets "temporary" to "value"
    And "client1" deletes "temporary"
    Then "client2" should see "temporary" is nil

  Scenario: All clients maintain consistency
    Given multiple clients are connected
    When "client1" sets "config" to "production"
    And "client2" sets "version" to "1.0.0"
    And "client3" sets "status" to "active"
    Then all clients should have the same data
