@Clockify-Final
Feature: Clockify-Final

  Background:
    Given base url $(env.base_url_clockify)

  ## All Workspace
   @getAllWorkspaces
  Scenario: Get all workspaces
    And endpoint /v1/workspaces
    And header x-api-key = $(env.api_key)
    When execute method GET
    Then the status code should be 200
    And response should be $.[5].name = Space_Elena
    * define workspaceId = $.[5].id

  ## Get Workspace Info
   @getWorkspaceInfo
  Scenario: Get workspace info
    Given call Clockify-Final.feature@getAllWorkspaces
    And endpoint /v1/workspaces/{{workspaceId}}
    And header x-api-key = $(env.api_key)
    When execute method GET
    Then the status code should be 200

  # Find All Users
   @findAllUsersOnWorkspace
  Scenario: Find all users on workspace
    Given call Clockify-Final.feature@getWorkspaceInfo
    And endpoint /v1/workspaces/{{workspaceId}}/users
    And header x-api-key = $(env.api_key)
    When execute method GET
    Then the status code should be 200
    And response should be $.[0].name = Elena Ojeda
    * define userId = $.[0].id

  # Get Time Entries for a User
   @getTimeEntriesForAUserOnWorkspace
  Scenario: Get time entries for a user on workspace
    Given call Clockify-Final.feature@findAllUsersOnWorkspace
    And endpoint /v1/workspaces/6720026e31f1716351f97542/user/{{userId}}/time-entries
    And header x-api-key = $(env.api_key)
    When execute method GET
    Then the status code should be 200
    * define idTime = $.[1].id

  # Add a new Time Entry
   @addANewTimeEntry
  Scenario: Add a new time entry
    * define timeEntry = read(jsons/bodies/addTimeE.json)
    Given call Clockify-Final.feature@getWorkspaceInfo
    And endpoint /v1/workspaces/{{workspaceId}}/time-entries
    And header x-api-key = $(env.api_key)
    And header accept = application/json
    And header Content-Type = application/json
    And body {{timeEntry}}
    When execute method POST
    Then the status code should be 201

  # Update Time Entry
   @updateTimeEntryOnWorkspace
  Scenario: Update time entry on workspace
    Given call Clockify-Final.feature@getTimeEntriesForAUserOnWorkspace
    And endpoint /v1/workspaces/6720026e31f1716351f97542/time-entries/{{idTime}}
    And header x-api-key = $(env.api_key)
    And header accept = application/json
    And header Content-Type = application/json
    And body jsons/bodies/putTime.json
    When execute method PUT
    Then the status code should be 200
    * define idTime = $.id

  # Delete Time Entry
  @test @deleteTimeEntryFromWorkspace
  Scenario: Delete time entry from workspace
    Given call Clockify-Final.feature@updateTimeEntryOnWorkspace
    And endpoint /v1/workspaces/6720026e31f1716351f97542/time-entries/{{idTime}}
    And header x-api-key = $(env.api_key)
    When execute method DELETE
    Then the status code should be 204