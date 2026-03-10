Feature: Judge management
  In order to control the competition flow
  As a referee
  I want to activate or deactivate judges and prevent unauthorized scoring

  @wip
  Scenario: Deactivated judge cannot submit a score
    Given judge "J1" is deactivated
    When judge "J1" tries to send a score
    Then the score should be rejected with message "Judge is deactivated"

  @wip
  Scenario: Referee activates a judge
    Given judge "J1" is deactivated
    When I activate judge "J1"
    Then judge "J1" should be active
