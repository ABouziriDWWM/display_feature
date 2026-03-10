Feature: PIN access
  In order to secure judge and referee areas
  As a user
  I want to sign in using a PIN with rate limiting and device binding

  @wip
  Scenario: Judge signs in with a valid PIN
    Given a judge PIN "1234" is active
    When I sign in as a judge with PIN "1234"
    Then I should be signed in as a judge

  @wip
  Scenario: Too many invalid attempts temporarily blocks the PIN
    Given a judge PIN "1234" is active
    When I enter an invalid PIN 5 times
    Then the judge sign-in should be temporarily blocked

  @wip
  Scenario: The same PIN cannot be used on two devices at the same time
    Given a judge PIN "1234" is active
    And the PIN "1234" is already bound to device "device-a"
    When I sign in as a judge with PIN "1234" from device "device-b"
    Then I should see an error "PIN already in use on another device"

  @wip
  Scenario: A referee can revoke a judge session
    Given a judge session exists for PIN "1234"
    When I revoke the session for PIN "1234"
    Then the judge session for PIN "1234" should be revoked
