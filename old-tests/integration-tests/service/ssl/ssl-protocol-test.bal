// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import http;
import ballerina/log;
import ballerina/stringutils;
import ballerina/test;

http:ListenerConfiguration sslProtocolServiceConfig = {
    secureSocket: {
        keyStore: {
            path: "src/http-tests/tests/integration-tests/certsAndKeys/ballerinaKeystore.p12",
            password: "ballerina"
         },
         protocol: {
             versions: ["TLSv1.1"]
         }
    }
};

listener http:Listener sslProtocolListener = new(9249, config = sslProtocolServiceConfig);

@http:ServiceConfig {
    basePath: "/protocol"
}
service sslProtocolService on sslProtocolListener {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/protocolResource"
    }
    resource function sayHello(http:Caller caller, http:Request req) {
        var result = caller->respond("Hello World!");
        if (result is error) {
           log:printError("Failed to respond", err = result);
        }
    }
}

http:ClientConfiguration sslProtocolClientConfig = {
    secureSocket: {
        trustStore: {
            path: "src/http-tests/tests/integration-tests/certsAndKeys/ballerinaTruststore.p12",
            password: "ballerina"
        },
        protocol: {
            versions: ["TLSv1.2"]
        }
    }
};

@test:Config {}
public function testSslProtocol() {
    http:Client clientEP = new("https://localhost:9249", sslProtocolClientConfig);
    http:Request req = new;
    var resp = clientEP->get("/protocol/protocolResource");
    if (resp is http:Response) {
        test:assertFail(msg = "Found unexpected output: Expected an error" );
    } else {
        test:assertTrue(stringutils:contains(resp.message(), "SSL connection failed"));
    }
}
