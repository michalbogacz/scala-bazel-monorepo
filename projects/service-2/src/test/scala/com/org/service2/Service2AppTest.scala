package com.org.service2

import org.scalatest.funsuite.AnyFunSuite

class Service2AppTest extends AnyFunSuite {

  test("Check log message") {
    assert(Service2App.secondMessage() == "Service 2 Starting..")
  }

}
