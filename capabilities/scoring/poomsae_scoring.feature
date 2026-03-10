Feature: Poomsae Scoring
  In order to ensure fair competition
  As a referee
  I want to calculate the score based on mistakes

  Scenario: Major mistake deduction
    Given a player starts with 10.0 points
    When the player commits a major mistake
    Then the score should be 9.7
