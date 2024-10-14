package com.org.service1

import com.org.initlog.Init

object Service1App extends App {

  println(Init.message)
  println(secondMessage())

  def secondMessage(): String = "Service 1 Starting.."
}
