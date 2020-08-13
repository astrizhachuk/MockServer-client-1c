#Region Internal

// @unit-test:prepare
Procedure MockServerDockerUp(Context) Export

	ExitStatus = Undefined;
	RunApp("docker kill mockserver-1c-integration", , True, ExitStatus);
	RunApp("docker run -d --rm -p 1080:1080"
						+ " --name mockserver-1c-integration mockserver/mockserver"
						+ " -logLevel DEBUG -serverPort 1080",
						,
						True,
						ExitStatus);
						
	If ExitStatus <> 0 Then
		
		Raise NStr("en = 'Container mockserver-1c-integration isn't created.'");
		
	EndIf;
	
	Wait(5);
	
EndProcedure

// @unit-test:integration
Procedure ExpectationFail(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	// when
	Mock.Server("localhost", "1080").When("{}").Respond();
	// then
	Assert.IsFalse(Mock.IsOk());

EndProcedure

// Request Properties Matcher Code Examples

// match request by path
// 
// @unit-test:integration
Procedure MatchRequestByPath(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	// when
	Mock.Server("localhost", "1080")
		.When(
			Mock.Request()
				.WithPath("/some/path")
		).Respond(
			Mock.Response()
				.WithBody("some_response_body")
		);
	// then
	Assert.IsTrue(Mock.IsOk());

EndProcedure

// match request by query parameter with regex value
// 
// @unit-test:integration
Procedure MatchRequestByQueryParameterWithRegexValue(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	// when
	Mock.Server("localhost", "1080")
		.When(
			Mock.Request()
				.WithPath("/some/path")
				.WithQueryStringParameters("cartId", "[A-Z0-9\\-]+")
				.WithQueryStringParameters("anotherId", "[A-Z0-9\\-]+")
		).Respond(
			Mock.Response()
				.WithBody("some_response_body")
		);
	// then
	Assert.IsTrue(Mock.IsOk());

EndProcedure

// Response Action Code Examples

// literal response with status code and reason phrase
// 
// @unit-test:integration
Procedure LiteralResponseWithStatusCodeAndReasonPhrase(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	// when
	Mock.Server("localhost", "1080")
		.When(
			Mock.Request()
				.WithPath("/some/path")
				.WithMethod("POST")
		).Respond(
			Mock.Response()
				.WithStatusCode(418)
				.WithReasonPhrase("I'm a teapot")
		);	
	// then
	Assert.IsTrue(Mock.IsOk());

EndProcedure

#Region VerifyingRepeatingRequests

// verify requests received at least twice
// 
// @unit-test:integration
Procedure VerifyRequestsReceivedAtLeastTwice(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server("localhost", "1080", true);
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	// when
	Mock.When(
			Mock.Request()
				.WithPath("/some/path")
		).Verify(
			Mock.Times()
				.AtLeast(2)
		);
	// then
	Assert.IsTrue(Mock.IsOk());
	Assert.IsTrue(Mock.Успешно());

EndProcedure

// @unit-test:integration
Procedure VerifyRequestsReceivedAtLeastTwiceFail(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server("localhost", "1080", true);
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	// when
	Mock.When(
			Mock.Request()
				.WithPath("/some/path")
		).Verify(
			Mock.Times()
				.AtLeast(2)
		);	
	// then
	Assert.IsFalse(Mock.IsOk());
	Assert.IsFalse(Mock.Успешно());

EndProcedure

// verify requests received at most twice
// 
// @unit-test:integration
Procedure VerifyRequestsReceivedAtMostTwice(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server("localhost", "1080", true);
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	HTTPConnector.Get( "http://localhost:1080/some/another" );
	// when
	Mock.When(
			Mock.Request()
				.WithPath("/some/path")
		).Verify(
			Mock.Times()
				.AtMost(2)
		);
	// then
	Assert.IsTrue(Mock.IsOk());
	Assert.IsTrue(Mock.Успешно());

EndProcedure

// @unit-test:integration
Procedure VerifyRequestsReceivedAtMostTwiceFail(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server("localhost", "1080", true);
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	// when
	Mock.When(
			Mock.Request()
				.WithPath("/some/path")
		).Verify(
			Mock.Times()
				.AtMost(2)
		);	
	// then
	Assert.IsFalse(Mock.IsOk());
	Assert.IsFalse(Mock.Успешно());

EndProcedure

// verify requests received exactly twice
// 
// @unit-test:integration
Procedure VerifyRequestsReceivedExactlyTwice(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server("localhost", "1080", true);
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	HTTPConnector.Get( "http://localhost:1080/some/another" );
	// when
	Mock.When(
			Mock.Request()
				.WithPath("/some/path")
		).Verify(
			Mock.Times()
				.Exactly(2)
		);
	// then
	Assert.IsTrue(Mock.IsOk());
	Assert.IsTrue(Mock.Успешно());

EndProcedure

// @unit-test:integration
Procedure VerifyRequestsReceivedExactlyTwiceFail(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server("localhost", "1080", true);
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	// when
	Mock.When(
			Mock.Request()
				.WithPath("/some/path")
		).Verify(
			Mock.Times()
				.Exactly(2)
		);	
	// then
	Assert.IsFalse(Mock.IsOk());
	Assert.IsFalse(Mock.Успешно());

EndProcedure

// verify requests received at exactly once
// 
// @unit-test:integration
Procedure VerifyRequestsReceivedOnce(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server("localhost", "1080", true);
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	HTTPConnector.Get( "http://localhost:1080/some/another" );
	// when
	Mock.When(
			Mock.Request()
				.WithPath("/some/path")
		).Verify(
			Mock.Times()
				.Once()
		);
	// then
	Assert.IsTrue(Mock.IsOk());
	Assert.IsTrue(Mock.Успешно());

EndProcedure

// @unit-test:integration
Procedure VerifyRequestsReceivedOnceFail(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server("localhost", "1080", true);
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	// when
	Mock.When(
			Mock.Request()
				.WithPath("/some/path")
		).Verify(
			Mock.Times()
				.Once()
		);	
	// then
	Assert.IsFalse(Mock.IsOk());
	Assert.IsFalse(Mock.Успешно());

EndProcedure

// verify requests received between n and m times
// 
// @unit-test:integration
Procedure VerifyRequestsReceivedBetween(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server("localhost", "1080", true);
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	// when
	Mock.When(
			Mock.Request()
				.WithPath("/some/path")
		).Verify(
			Mock.Times()
				.Between(2, 3)
		);
	// then
	Assert.IsTrue(Mock.IsOk());
	Assert.IsTrue(Mock.Успешно());

EndProcedure

// @unit-test:integration
Procedure VerifyRequestsReceivedBetweenLessFail(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server("localhost", "1080", true);
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	// when
	Mock.When(
			Mock.Request()
				.WithPath("/some/path")
		).Verify(
			Mock.Times()
				.Between(2, 3)
		);	
	// then
	Assert.IsFalse(Mock.IsOk());
	Assert.IsFalse(Mock.Успешно());

EndProcedure

// @unit-test:integration
Procedure VerifyRequestsReceivedBetweenMoreFail(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server("localhost", "1080", true);
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	// when
	Mock.When(
			Mock.Request()
				.WithPath("/some/path")
		).Verify(
			Mock.Times()
				.Between(2, 3)
		);	
	// then
	Assert.IsFalse(Mock.IsOk());
	Assert.IsFalse(Mock.Успешно());

EndProcedure

// verify requests never received
// 
// @unit-test:integration
Procedure VerifyRequestsNeverReceived(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server("localhost", "1080", true);
	// when
	Mock.When(
			Mock.Request()
				.WithPath("/some/path")
		).Verify(
			Mock.Times()
				.Exactly(0)
		);
	// then
	Assert.IsTrue(Mock.IsOk());
	Assert.IsTrue(Mock.Успешно());

EndProcedure

// @unit-test:integration
Procedure VerifyRequestsNeverReceivedFail(Context) Export

	// given
	Mock = DataProcessors.MockServerClient.Create();
	Mock.Server("localhost", "1080", true);
	HTTPConnector.Get( "http://localhost:1080/some/path" );
	// when
	Mock.When(
			Mock.Request()
				.WithPath("/some/path")
		).Verify(
			Mock.Times()
				.Exactly(0)
		);	
	// then
	Assert.IsFalse(Mock.IsOk());
	Assert.IsFalse(Mock.Успешно());

EndProcedure

#EndRegion

#EndRegion

#Region Private

Procedure Wait( Val Wait) Export
	
	End = CurrentDate() + Wait;
	
	While (True) Do
		
		If CurrentDate() >= End Then
			Return;
		EndIf;
		 
	EndDo;
	 
EndProcedure

#EndRegion
