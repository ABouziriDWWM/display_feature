Feature: Language toggle
  In order to support bilingual competitions
  As a user
  I want to switch the UI between French and English

  @wip @javascript
  Scenario: Default language is French
    Given I am on the home page
    Then the UI language should be "fr"

  @wip @javascript
  Scenario: User switches to English and it applies to the whole UI
    Given I am on the home page
    When I switch the language to "en"
    Then the UI language should be "en"
    And I should see "Current score"
    And I should see a button "Reset"
