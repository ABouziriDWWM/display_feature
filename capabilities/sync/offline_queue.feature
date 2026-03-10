Feature: Offline queue and sync
  In order to keep working without internet
  As a judge
  I want scores to be queued offline and synced when the network is back

  @wip @javascript
  Scenario: [Queueing] Score is queued when sending without network
    Given I am signed in as a judge
    And the network is offline
    And I have a complete score ready to send
    When I tap "Send"
    Then the score should be queued locally
    And I should see a badge "to sync"

  @wip @javascript
  Scenario: [Queueing] Score is sent immediately when network is available
    Given I am signed in as a judge
    And the network is back online
    And I have a complete score ready to send
    When I tap "Send"
    Then the score should be sent to the PC
    And the score should not be queued locally

  @wip @javascript
  Scenario: [Queueing] Double tap does not queue duplicates
    Given I am signed in as a judge
    And the network is offline
    And I have a complete score ready to send
    When I tap "Send" twice
    Then only 1 score should be queued locally

  @wip @javascript
  Scenario: [Queueing] Queued scores persist after refresh
    Given I have 2 queued scores
    When I refresh the page
    Then I should still have 2 queued scores

  @wip @javascript
  Scenario: [Sync] Queued scores are synced when the network comes back
    Given I have 2 queued scores
    And the network is back online
    When the app syncs
    Then the queued scores should be sent to the PC

  @wip @javascript
  Scenario: [Sync] Partial sync keeps failed items queued
    Given I have 2 queued scores
    And the network is back online
    And 1 queued score will fail to send
    When the app syncs
    Then 1 queued score should remain locally
