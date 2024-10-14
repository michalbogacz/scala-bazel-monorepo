package com.org.service2

import com.org.initlog.Init

object Service2App extends App {

  println(Init.message)
  println(secondMessage())

  def secondMessage(): String = "Service 2 Starting.."
}
