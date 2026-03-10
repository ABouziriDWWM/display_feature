Feature: Scoreboard table
  In order to follow the competition on a PC
  As a referee
  I want to see judge scores per athlete and the computed final score

  @wip
  Scenario: Scoreboard shows an athlete row with judge totals and final score
    Given a competition exists with a 5-judge jury
    And athlete "Kim Minji" is the current athlete
    When the PC receives judge totals:
      | judge | total |
      | J1    | 9.9   |
      | J2    | 9.8   |
      | J3    | 9.7   |
      | J4    | 10.0  |
      | J5    | 9.5   |
    Then the scoreboard should show final score 9.8 for "Kim Minji"

  @wip
  Scenario: Final score is recalculated whenever a judge score arrives
    Given a competition exists with a 5-judge jury
    And athlete "Kim Minji" is the current athlete
    When the PC receives judge total 9.9 from "J1"
    And the PC receives judge total 9.8 from "J2"
    Then the scoreboard should show "waiting for scores"
