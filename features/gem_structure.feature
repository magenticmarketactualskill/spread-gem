Feature: Gem Structure and API
  As a Ruby developer
  I want to use SpreadGem with a clean Ruby API
  So that I can easily integrate it into my applications

  Scenario: Gem has a version
    Then the gem should have a version number

  Scenario: Gem defines core classes
    Then the gem should define the "Client" class
    And the gem should define the "Store" class
    And the gem should define the "Connection" class
    And the gem should define the "Message" class

  Scenario: Handle connection errors gracefully
    Given a client named "test_client" is connected
    When "test_client" attempts to connect to an invalid server
    Then a ConnectionError should be raised
