Feature: Judge management
  In order to control the competition flow
  As a referee
  I want to activate or deactivate judges and prevent unauthorized scoring

  @wip
  Scenario: [Authorization] Deactivated judge cannot submit a score
    Given judge "J1" is deactivated
    When judge "J1" tries to send a score
    Then the score should be rejected with message "Judge is deactivated"

  @wip
  Scenario: [Authorization] Active judge can submit a score
    Given judge "J1" is active
    When judge "J1" tries to send a score
    Then the score should be accepted

  @wip
  Scenario: [Admin] Referee activates a judge
    Given judge "J1" is deactivated
    When I activate judge "J1"
    Then judge "J1" should be active

  @wip
  Scenario: [Admin] Activating an already active judge does not change state
    Given judge "J1" is active
    When I activate judge "J1"
    Then judge "J1" should be active

  @wip
  Scenario: [Admin] Deactivating an already deactivated judge does not change state
    Given judge "J1" is deactivated
    When I deactivate judge "J1"
    Then judge "J1" should be deactivated
