# thor
Demo app for the unit testing talk at Pune Cocoa Devs meetup

# Generative testing 
Externals/Fox contains the Fox project used for Generative testing.
ThorTests.m have the generative test examples with Queue.[h/m] being the helper class for test.

# Network stack tests
HsTransport is the NSURLSession based transport stack.
HsMockApiServer class implements the mocking required for making foreground session calls with NSURLSession.
ThorNetworkTests are the network tests which show usages.

# Basic unit tests
HsKeyValueBundleStorage is a KV store implemented on top of UserDefaults.
HsKeyValueStorageTests are the behavioral unit tests for the Storage class.

