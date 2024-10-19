package com.org.service1

import org.scalatest.funsuite.AnyFunSuite

class Service1AppITTest extends AnyFunSuite {

  test("Check log message") {
    assert(Service1App.secondMessage() == "Service 1 Starting..")
  }

}
