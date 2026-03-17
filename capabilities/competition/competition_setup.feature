Feature: Competition setup
  In order to run a competition on a PC
  As a referee
  I want to create and configure a competition with athletes and jury settings

  Scenario: Create a competition with basic information
    Given I am signed in as a referee
    When I create a competition with:
      | name  | date       | location |
      | Open  | 2026-03-10 | Paris    |
    Then the competition should be created

  Scenario: Configure the jury size in official mode
    Given a competition exists
    When I set the jury size to 5 in official mode
    Then the jury size should be 5

  Scenario: Add athletes with club and group information
    Given a competition exists
    When I add the following athletes:
      | name      | group | club        |
      | Kim Minji | A     | Taekwondo 77 |
      | Lee Joon  | B     | WT Club      |
    Then the athlete list should contain 2 athletes
