Feature: Public results display
  In order to publish results to spectators
  As a public user
  I want a read-only page showing current rankings

  @javascript
  Scenario: Public page is accessible without authentication
    Given I am on the public results page
    Then I should see the current category
    And I should see the ranking table

  @javascript
  Scenario: Public page does not allow score editing
    Given I am on the public results page
    Then I should not see any editable score inputs

  @javascript
  Scenario: Spectator entry point exists from the home page
    Given I am on the home page
    When I follow "Spectator"
    Then I should see "Jeu spectator"

  @javascript
  Scenario: Spectator can open the game using the current competition id
    Given I create a competition for spectator
    When I open the spectator game for the current competition
    Then I should see "Compétition"

  @javascript
  Scenario: Spectator can open the public results from the spectator game
    Given I create a competition for spectator
    When I open the spectator game for the current competition
    And I follow "Affichage public"
    Then I should see the current category
    And I should see the ranking table

  @javascript
  Scenario: Judge area is protected when accessed from spectator game
    Given I create a competition for spectator
    When I open the spectator game for the current competition
    And I follow "Espace juge"
    Then I should eventually see "Choisir un rôle"
