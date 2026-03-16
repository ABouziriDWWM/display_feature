Feature: Realtime judges and admin
  In order to run the competition smoothly
  As an admin
  I want to receive judges actions in realtime and control who can submit

  @realtime
  Scenario: [Realtime] Judge submission appears on admin feed
    Given the system is reset for realtime tests
    And judge "J1" is active and signed in
    And the admin is listening to live events
    When judge "J1" submits a score "9.9"
    Then the admin should receive a "score_submitted" event for judge "J1"

  @realtime
  Scenario: [Realtime] Deactivated judge cannot submit and admin receives no score event
    Given the system is reset for realtime tests
    And judge "J1" is active and signed in
    And the admin is listening to live events
    When the admin deactivates judge "J1"
    And judge "J1" submits a score "9.9"
    Then the submission should be rejected
    And the admin should not receive any "score_submitted" event for judge "J1"
