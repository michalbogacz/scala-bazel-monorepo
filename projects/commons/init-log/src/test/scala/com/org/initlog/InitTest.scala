package com.org.initlog

import org.scalatest.funsuite.AnyFunSuite

class InitTest extends AnyFunSuite {
  test("Check log message") {
    assert(Init.message == "Scala example monorepo!")
  }
}