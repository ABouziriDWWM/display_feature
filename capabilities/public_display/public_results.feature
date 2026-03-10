Feature: Public results display
  In order to publish results to spectators
  As a public user
  I want a read-only page showing current rankings

  @wip @javascript
  Scenario: Public page is accessible without authentication
    Given I am on the public results page
    Then I should see the current category
    And I should see the ranking table

  @wip @javascript
  Scenario: Public page does not allow score editing
    Given I am on the public results page
    Then I should not see any editable score inputs
