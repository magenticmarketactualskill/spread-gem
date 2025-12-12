Feature: Nested Object Synchronization
  As a developer using SpreadGem
  I want to work with nested objects
  So that I can organize complex data structures

  Background:
    Given a SpreadJS server is running

  Scenario: Synchronize nested objects
    Given a client named "client1" is connected
    And a client named "client2" is connected
    When "client1" sets a nested value at "config.database.host" to "localhost"
    Then "client2" should see nested value at "config.database.host" equals "localhost"

  Scenario: Multiple nested levels
    Given a client named "alice" is connected
    And a client named "bob" is connected
    When "alice" sets a nested value at "app.settings.ui.theme" to "dark"
    And "alice" sets a nested value at "app.settings.ui.language" to "en"
    Then "bob" should see nested value at "app.settings.ui.theme" equals "dark"
    And "bob" should see nested value at "app.settings.ui.language" equals "en"

  Scenario: Update nested values
    Given a client named "client1" is connected
    And a client named "client2" is connected
    When "client1" sets a nested value at "user.profile.name" to "John"
    And "client1" sets a nested value at "user.profile.name" to "Jane"
    Then "client2" should see nested value at "user.profile.name" equals "Jane"
