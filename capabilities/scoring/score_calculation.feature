Feature: Score calculation
  In order to rank competitors fairly
  As a referee
  I want to calculate final scores according to official rules

  Scenario: Final score discards the highest and lowest for a 5-judge jury
    Given the following judge totals:
      | total |
      | 10.0  |
      | 9.5   |
      | 9.9   |
      | 9.8   |
      | 9.7   |
    When I calculate the final score
    Then the final score should be 9.8

  Scenario: Final score discards the highest and lowest for a 7-judge jury
    Given the following judge totals:
      | total |
      | 10.0  |
      | 9.9   |
      | 9.8   |
      | 9.7   |
      | 9.6   |
      | 9.5   |
      | 9.4   |
    When I calculate the final score
    Then the final score should be 9.7

  Scenario: Final round averages two performances
    Given performance 1 final score is 9.8
    And performance 2 final score is 9.6
    When I calculate the final round score
    Then the final round score should be 9.7

  Scenario: Tie-break uses presentation score first, then the sum of all judges points
    Given the following tied competitors:
      | name  | total | presentation | sum_of_judges |
      | Alice | 9.7   | 5.8          | 48.5          |
      | Bob   | 9.7   | 5.8          | 48.3          |
    When I apply tie-break rules
    Then the winner should be Alice
