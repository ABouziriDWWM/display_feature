Feature: Poomsae Scoring
  In order to ensure fair competition
  As a referee
  I want to calculate the score based on mistakes

  Scenario: [Deductions] Major mistake deduction
    Given a player starts with 10.0 points
    When the player commits a major mistake
    Then the score should be 9.7

  Scenario: [Deductions] Minor mistake deduction
    Given a player starts with 10.0 points
    When the player commits a minor mistake
    Then the score should be 9.9

  Scenario: [Deductions] Multiple deductions are cumulative
    Given a player starts with 10.0 points
    When the player commits a minor mistake
    And the player commits a minor mistake
    And the player commits a major mistake
    Then the score should be 9.5

  Scenario: [Bounds] Score floors at zero on major deduction
    Given a player starts with 0.2 points
    When the player commits a major mistake
    Then the score should be 0.0

  Scenario: [Bounds] Score floors at zero on minor deduction
    Given a player starts with 0.0 points
    When the player commits a minor mistake
    Then the score should be 0.0

  Scenario: [Input] Start score accepts comma decimal separator
    Given a player starts with 10,0 points
    When the player commits a minor mistake
    Then the score should be 9.9
