Feature: PIN access
  In order to secure judge and referee areas
  As a user
  I want to sign in using a PIN with rate limiting and device binding

  Scenario: [Sign in] Judge signs in with a valid PIN
    Given a judge PIN "1234" is active
    When I sign in as a judge with PIN "1234"
    Then I should be signed in as a judge

  Scenario: [Sign in] Judge cannot sign in with an inactive PIN
    Given a judge PIN "1234" is inactive
    When I sign in as a judge with PIN "1234"
    Then I should see an error "Invalid PIN"

  Scenario: [Sign in] Judge cannot sign in with a non-numeric PIN
    Given a judge PIN "1234" is active
    When I sign in as a judge with PIN "12ab"
    Then I should see an error "Invalid PIN format"

  Scenario: [Sign in] Judge cannot sign in with a PIN of the wrong length
    Given a judge PIN "1234" is active
    When I sign in as a judge with PIN "123"
    Then I should see an error "Invalid PIN format"

  Scenario: [Rate limiting] Too many invalid attempts temporarily blocks the PIN
    Given a judge PIN "1234" is active
    When I enter an invalid PIN 5 times
    Then the judge sign-in should be temporarily blocked

  Scenario: [Rate limiting] A successful sign-in resets the invalid attempt counter
    Given a judge PIN "1234" is active
    And I entered an invalid PIN 2 times
    When I sign in as a judge with PIN "1234"
    Then the judge sign-in should not be temporarily blocked

  Scenario: [Device binding] The same PIN cannot be used on two devices at the same time
    Given a judge PIN "1234" is active
    And the PIN "1234" is already bound to device "device-a"
    When I sign in as a judge with PIN "1234" from device "device-b"
    Then I should see an error "PIN already in use on another device"

  Scenario: [Device binding] The same device can sign in again with the same PIN
    Given a judge PIN "1234" is active
    And the PIN "1234" is already bound to device "device-a"
    When I sign in as a judge with PIN "1234" from device "device-a"
    Then I should be signed in as a judge

  Scenario: [Sessions] A referee can revoke a judge session
    Given a judge session exists for PIN "1234"
    When I revoke the session for PIN "1234"
    Then the judge session for PIN "1234" should be revoked

  Scenario: [Roles] Admin generates a referee PIN, referee generates judge PINs
    When I sign in as admin with PIN "9999"
    And I generate a referee PIN for name "R1"
    And I sign in as referee "R1" with PIN from last admin generation
    And I generate 5 judge PINs as the signed-in referee
    Then I should receive 5 judge PINs
    And I should be able to sign in as a judge with the first generated judge PIN

  @javascript
  Scenario: [UI] Login page role buttons show the right form
    Given the browser storage is cleared
    When I go to "/login.html"
    And I choose the "admin" role
    Then the "admin" sign-in form should be visible
    And the "judge" sign-in form should be hidden
    When I choose the "judge" role
    Then the "judge" sign-in form should be visible
    And the "admin" sign-in form should be hidden

  @javascript
  Scenario: [UI] Admin page redirects to login when not authenticated
    Given the browser storage is cleared
    When I go to "/admin.html"
    Then I should see "Choisir un rôle"

  @javascript
  Scenario: [UI] Admin can generate a referee PIN from the UI
    Given the browser storage is cleared
    When I sign in as admin with PIN "9999"
    And I store the admin token in the browser
    And I go to "/admin.html"
    When I fill in "refereeName" with "R1"
    And I click "Générer"
    Then the generated referee PIN should be displayed

  @javascript
  Scenario: [UI] Admin can sign out and loses access to admin page
    Given the browser storage is cleared
    When I sign in as admin with PIN "9999"
    And I store the admin token in the browser
    And I go to "/admin.html"
    When I follow "Déconnexion"
    Then I should see "Choisir un rôle"
    When I go to "/admin.html"
    Then I should see "Choisir un rôle"

  @javascript
  Scenario: [UI] Referee can generate judge PINs from the UI
    Given the browser storage is cleared
    When I sign in as admin with PIN "9999"
    And I generate a referee PIN for name "R1"
    And I sign in as referee "R1" with PIN from last admin generation
    And I store the referee token in the browser
    And I go to "/referee.html"
    When I choose a jury size of "5"
    And I click "Générer les PIN"
    Then I should see 5 judge pins

  @javascript
  Scenario: [UI] Referee page redirects to login when not authenticated
    Given the browser storage is cleared
    When I go to "/referee.html"
    Then I should see "Choisir un rôle"

  @javascript
  Scenario: [UI] Referee can sign out and loses access to referee page
    Given the browser storage is cleared
    When I sign in as admin with PIN "9999"
    And I generate a referee PIN for name "R1"
    And I sign in as referee "R1" with PIN from last admin generation
    And I store the referee token in the browser
    And I go to "/referee.html"
    When I follow "Déconnexion"
    Then I should see "Choisir un rôle"
    When I go to "/referee.html"
    Then I should see "Choisir un rôle"

  @javascript
  Scenario: [UI] Judge page redirects to login when not authenticated
    Given the browser storage is cleared
    When I go to "/judge"
    Then I should see "Choisir un rôle"
