Feature: Offline queue and sync
  In order to keep working without internet
  As a judge
  I want scores to be queued offline and synced when the network is back

  @wip @javascript
  Scenario: Score is queued when sending without network
    Given I am signed in as a judge
    And the network is offline
    And I have a complete score ready to send
    When I tap "Send"
    Then the score should be queued locally
    And I should see a badge "to sync"

  @wip @javascript
  Scenario: Queued scores are synced when the network comes back
    Given I have 2 queued scores
    And the network is back online
    When the app syncs
    Then the queued scores should be sent to the PC
