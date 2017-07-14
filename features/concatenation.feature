Feature: Concatenation

  Scenario: Creating partial upload
    When I make a POST request to /files
      """
      Tus-Resumable: 1.0.0
      Upload-Length: 5
      Upload-Concat: partial
      """
    Then I should see response status "201 Created"
    And I should see response headers
      """
      Upload-Concat: partial
      """

  Scenario: Creating final upload
    Given a file
      """
      Upload-Length: 5
      Upload-Concat: partial

      hello
      """
    And a file
      """
      Upload-Length: 6
      Upload-Concat: partial

       world
      """
    When I send a concatenation request for the created files
    Then I should see response status "201 Created"
    And I should see response headers
      """
      Upload-Length: 11
      Upload-Offset: 11
      """
    And "Upload-Concat" response header should match "^final;/files/\w+ /files/\w+$"

    When I make a HEAD request to the concatenated file
      """
      Tus-Resumable: 1.0.0
      """
    Then I should see response status "204 No Content"
    And I should see response headers
      """
      Upload-Length: 11
      Upload-Offset: 11
      """
    And "Upload-Concat" response header should match "^final;/files/\w+ /files/\w+$"

    When I make a GET request to the concatenated file
      """
      """
    Then I should see response status "200 OK"
    And I should see "hello world"

  Scenario: Invalid Upload-Concat
    When I make a POST request to /files
      """
      Tus-Resumable: 1.0.0
      Upload-Length: 5
      Upload-Concat: foo
      """
    Then I should see response status "400 Bad Request"
    And I should see "Invalid Upload-Concat header"