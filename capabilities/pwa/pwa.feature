Feature: Poomsae Referee PWA
  In order to use the application without internet
  As a referee at a competition
  I want to install the application and use it offline

  Scenario: [Installability] Application is installable
    Given I am on the home page
    Then I should see the manifest file linked
    And I should see the service worker registration
    And the theme color should be "#0d6efd"

  Scenario: [Offline] Service worker is available for offline mode
    Given I am on the home page
    When I go to "/sw.js"
    Then the response should contain "caches.open"

  Scenario: [Haptics] Judges score buttons trigger vibration feedback
    Given I am on the home page
    Then score buttons should trigger vibration feedback

  @wip @javascript
  Scenario: [Offline] Home page loads from cache when offline after first visit
    Given I am on the home page
    And I have already loaded the app once
    And the network is offline
    When I refresh the page
    Then the score display should show "10.0"

  @wip @javascript
  Scenario: [Offline] Core assets are available offline
    Given I have already loaded the app once
    And the network is offline
    When I go to "/manifest.json"
    Then the response should contain "Poomsae Referee"
    When I go to "/icons/icon.svg"
    Then the response should contain "<svg"

  @javascript
  Scenario: Scoring updates the score display
    Given I am on the home page
    Then the score display should show "10.0"
    When I click "Faute Mineure (-0.1)"
    Then the score display should show "9.9"
    When I click "Réinitialiser"
    Then the score display should show "10.0"
