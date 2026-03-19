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

  @javascript
  Scenario: [Offline] Home page loads from cache when offline after first visit
    Given I am on the home page
    And I have already loaded the app once
    And the network is offline
    When I refresh the page
    Then I should see "Installer l’application"

  @javascript
  Scenario: [Offline] Core assets are available offline
    Given I have already loaded the app once
    And the network is offline
    When I go to "/manifest.json"
    Then the response should contain "Poomsae Referee"
    When I go to "/icons/icon.svg"
    Then the response should contain "<svg"
    When I go to "/login.html"
    Then the response should contain "Connexion"

  @javascript
  Scenario: Login page is accessible from the home page
    Given I am on the home page
    When I follow "Se connecter"
    Then I should see "Choisir un rôle"
