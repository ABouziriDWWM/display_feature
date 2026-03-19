Feature: Language toggle
  In order to support bilingual competitions
  As a user
  I want to switch the UI between French and English

  @javascript
  Scenario: [Defaults] Default language is French
    Given I am on the home page
    Then the UI language should be "fr"

  @javascript
  Scenario: [Switching] User switches to English and it applies to the whole UI
    Given I am on the home page
    When I switch the language to "en"
    Then the UI language should be "en"
    And I should see "Install the app"
    And I should see "Sign in"

  @javascript
  Scenario: [Persistence] Language choice is persisted after refresh
    Given I am on the home page
    When I switch the language to "en"
    And I refresh the page
    Then the UI language should be "en"

  @javascript
  Scenario: [Persistence] Language choice is applied on the login page
    Given I am on the home page
    When I switch the language to "en"
    And I go to "/login.html"
    Then the UI language should be "en"
    And I should see "Choose a role"

  @javascript
  Scenario: [Fallback] Unsupported language falls back to French
    Given I am on the home page
    When I switch the language to "es"
    Then the UI language should be "fr"
