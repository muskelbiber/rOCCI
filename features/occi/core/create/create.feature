Feature:
  In order to create an OCCI Resource on the OCCI Server
  As an OCCI Client
  I want to get an success report of the create operation and receive the URI of the new Resource by the OCCI Server

  @vcr_record
  Scenario Outline: Create an OCCI Resource
    Given endpoint : <endpoint>
    And transfer_protocol : <protocol>
    And accept type : <accept_type>
    And have an initialize Client
    When the Client makes a create request
    Then the Client should have the response code <response_code>

  @vcr_record
  Scenarios:
    | protocol  | endpoint                  | accept_type       | response_code |
    | http      | http://141.5.99.69/       | text/plain        | 201           |
