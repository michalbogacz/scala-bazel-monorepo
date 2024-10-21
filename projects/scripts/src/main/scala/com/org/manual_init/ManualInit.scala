package projects.scripts.src.main.scala.com.org.manual_init

import com.org.initlog.Init

object ManualInit {

  def main(args: Array[String]): Unit = {
    println(s"SCRIPT> Starting with args: ${args.mkString("(", ", ", ")")}")
    println(s"SCRIPT> Message from service init: ${Init.message}")
  }
}
