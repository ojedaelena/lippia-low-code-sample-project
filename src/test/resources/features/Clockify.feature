Feature: Clockify

  Background:
    Given base url $(env.base_url_clockify)

    ## Workspace
  @getAllWorkspaces
  Scenario: getAllWorkspaces
    And endpoint /v1/workspaces
    And header x-api-key = $(env.api_key)
    When execute method GET
    Then the status code should be 200
    And response should be $.[8].name = newWorkspace
    * define workspaceId = $.[8].id


  @getWorkspaceInfo
  Scenario: getWorkspaceInfo
    Given call Clockify.feature@getAllWorkspaces
    And base url https://api.clockify.me/api
    And endpoint /v1/workspaces/{{workspaceId}}
    And header x-api-key = $(env.api_key)
    When execute method GET
    Then the status code should be 200

  ## Project
  @addNewProject
  Scenario: addNewProject
    * define project = read(jsons/bodies/addProj.json)
    And base url $(env.base_url_clockify)
    And endpoint /v1/workspaces/$(env.id_workspace)/projects
    And header x-api-key = $(env.api_key)
    And header accept = application/json
    And header Content-Type = application/json
    And body {{project}}
    When execute method POST
    Then the status code should be 201


  @getAllProjects
  Scenario: getAllProjects
    And base url $(env.base_url_clockify)
    And endpoint /v1/workspaces/$(env.id_workspace)/projects
    And header x-api-key = $(env.api_key)
    When execute method GET
    Then the status code should be 200
    And response should be $.[0].name = project1
    * define projectId = $.[0].id

   @findProjectByID
  Scenario: Find project by ID
    And base url $(env.base_url_clockify)
    And endpoint /v1/workspaces/$(env.id_workspace)/projects/67169ed17cce8d028e29e6c7
    And header x-api-key = $(env.api_key)
    When execute method GET
    Then the status code should be 200

  @addNewProjectToDelete
  Scenario: addNewProjectToDelete
    * define project = read(jsons/bodies/addProj2.json)
    And base url $(env.base_url_clockify)
    And endpoint /v1/workspaces/67199199f251712419b07f4a/projects
    And header x-api-key = $(env.api_key)
    And header accept = application/json
    And header Content-Type = application/json
    And body {{project}}
    When execute method POST
    Then the status code should be 201

  @getAllProjectsToDelete
  Scenario: getAllProjects
    And base url $(env.base_url_clockify)
    And endpoint /v1/workspaces/67199199f251712419b07f4a/projects
    And header x-api-key = $(env.api_key)
    When execute method GET
    Then the status code should be 200
    * define projectId = $.[3].id

  @putProjectsToDelete
  Scenario: putProjects
    Given call Clockify.feature@getAllProjectsToDelete
    And base url $(env.base_url_clockify)
    And endpoint /v1/workspaces/67199199f251712419b07f4a/projects/{{projectId}}
    And header x-api-key = $(env.api_key)
    And header accept = application/json
    And header Content-Type = application/json
    And body jsons/bodies/putProj.json
    When execute method PUT
    Then the status code should be 200
    * define projectId = $.id

  @deleteProject
  Scenario: deleteProject
    Given call Clockify.feature@addNewProjectToDelete
    And call Clockify.feature@putProjectsToDelete
    And base url $(env.base_url_clockify)
    And endpoint /v1/workspaces/67199199f251712419b07f4a/projects/{{projectId}}
    And header x-api-key = $(env.api_key)
    When execute method DELETE
    Then the status code should be 200



  @unauthorized401 @fail
  Scenario: Find project by ID failed to unauthorized
    And base url $(env.base_url_clockify)
    And endpoint /v1/workspaces/$(env.id_workspace)/projects/$(env.id_project)
    And header x-api-key = $(env.api_key_false)
    When execute method GET
    Then the status code should be 401

  @projectNotFound404 @fail
  Scenario: Find Non existent project by ID
    And base url $(env.base_url_clockify)
    And endpoint /v1/workspaces/$(env.id_workspace)/projects/{{notProject}}
    And header x-api-key = $(env.api_key)
    When execute method GET
    Then the status code should be 404


  @badRequest400 @fail
  Scenario: Add new project failed - Body without name project
    * define project = read(jsons/bodies/addProjError.json)
    And base url $(env.base_url_clockify)
    And endpoint /v1/workspaces/$(env.id_workspace)/projects
    And header x-api-key = $(env.api_key)
    And header accept = application/json
    And header Content-Type = application/json
    And body {{project}}
    When execute method POST
    Then the status code should be 400
