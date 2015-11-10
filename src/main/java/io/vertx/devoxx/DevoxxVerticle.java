package io.vertx.devoxx;

import io.vertx.core.AbstractVerticle;
import io.vertx.core.eventbus.Message;
import io.vertx.core.http.HttpHeaders;
import io.vertx.core.json.JsonObject;
import io.vertx.ext.web.Router;
import io.vertx.ext.web.handler.StaticHandler;
import io.vertx.ext.web.handler.sockjs.BridgeOptions;
import io.vertx.ext.web.handler.sockjs.PermittedOptions;
import io.vertx.ext.web.handler.sockjs.SockJSHandler;
import io.vertx.ext.web.templ.JadeTemplateEngine;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * Created by plopes on 11/10/15.
 */
public class DevoxxVerticle extends AbstractVerticle {

  @Override
  public void start() {
    Router router = Router.router(vertx);
    JadeTemplateEngine jade = JadeTemplateEngine.create();
    AtomicInteger cnt = new AtomicInteger();

    final BridgeOptions options = new BridgeOptions()
        .addInboundPermitted(new PermittedOptions().setAddress("memleak-hunt"))
        .addInboundPermitted(new PermittedOptions().setAddress("memleak-hunt-score"))
        .addOutboundPermitted(new PermittedOptions().setAddress("memleak-hunt"));


    router.route("/eventbus/*").handler(SockJSHandler.create(vertx).bridge(options));

    router.get("/game").handler(ctx -> {
      ctx.put("playerId", cnt.getAndIncrement());

      jade.render(ctx, "templates/game", res -> {
        if (res.succeeded()) {
          ctx.response().putHeader(HttpHeaders.CONTENT_TYPE, "text/html").end(res.result());
        } else {
          ctx.fail(res.cause());
        }
      });
    });
    router.route().handler(StaticHandler.create());

    vertx.createHttpServer().requestHandler(router::accept).listen(8080);

    vertx.eventBus().consumer("memleak-hunt-score", (Message<JsonObject> msg) -> {
      System.out.println(msg.body().encode());
    });

  }
}
