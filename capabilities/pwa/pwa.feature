Feature: Poomsae Referee PWA
  In order to use the application without internet
  As a referee at a competition
  I want to install the application and use it offline

  Scenario: Application is installable
    Given I am on the home page
    Then I should see the manifest file linked
    And I should see the service worker registration
    And the theme color should be "#0d6efd"

  Scenario: Service worker is available for offline mode
    Given I am on the home page
    When I go to "/sw.js"
    Then the response should contain "caches.open"

  @javascript
  Scenario: Scoring updates the score display
    Given I am on the home page
    Then the score display should show "10.0"
    When I click "Faute Mineure (-0.1)"
    Then the score display should show "9.9"
    When I click "Réinitialiser"
    Then the score display should show "10.0"
