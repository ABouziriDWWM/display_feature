Feature: Judge scoring flow
  In order to score quickly on a phone or tablet
  As a judge
  I want a two-step input for accuracy and presentation with safe boundaries

  @wip @javascript
  Scenario: Accuracy starts at 4.0 and applies deductions and corrections
    Given I am signed in as a judge
    And I am scoring the current athlete
    When I start the accuracy step
    Then the accuracy score should be 4.0
    When I tap "-0.3" 3 times
    Then the accuracy score should be 3.1
    When I tap "+0.1" once
    Then the accuracy score should be 3.2
    And the accuracy score should be between 0.0 and 4.0

  @wip @javascript
  Scenario: Presentation is entered as three sub-scores on 2.0 each
    Given I am signed in as a judge
    And I am on the presentation step
    When I set "Speed & Power" to 1.9
    And I set "Rhythm & Tempo" to 1.8
    And I set "Energy Expression" to 2.0
    Then the presentation total should be 5.7
    And the presentation score should be between 0.0 and 6.0

  @wip @javascript
  Scenario: Send prevents accidental double submit
    Given I am signed in as a judge
    And I have a complete score ready to send
    When I tap "Send" twice quickly
    Then the score should be sent only once
