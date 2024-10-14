package com.org.service1

import org.scalatest.funsuite.AnyFunSuite
import com.org.service1.Service1App

class Service1AppTest extends AnyFunSuite {

  test("Check log message") {
    assert(Service1App.secondMessage() == "Service 1 Starting..")
  }

}
