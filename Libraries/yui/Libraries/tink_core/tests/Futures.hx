package ;

using tink.CoreApi;

@:asserts
class Futures extends Base {
  public function testsync() {
    var f = Future.sync(4);
    var x = -4;
    f.handle(function (v) x = v);
    asserts.assert(4 == x);
    return asserts.done();
  }
  
  public function testOfAsyncCall() {
    var callbacks:Array<Int->Void> = [];
    function fake(callback:Int->Void) {
      callbacks.push(callback);
    }
    function trigger() 
      for (c in callbacks) c(4);
    
    var f = Future.async(fake);
    
    var calls = 0;
    
    var link1 = f.handle(function () calls++),
      link2 = f.handle(function () calls++);
      
    f.handle(function (v) {
      asserts.assert(4 == v);
      calls++;
    });
    
    asserts.assert(1 == callbacks.length);
    link1.dissolve();
    
    trigger();
    
    asserts.assert(2 == calls);
    return asserts.done();
  }
  
  public function testTrigger() {
    var t = Future.trigger();
    asserts.assert(t.trigger(4));
    asserts.assert(!t.trigger(4));
    
    t = Future.trigger();
    
    var f:Future<Int> = t;
    
    var calls = 0;
    
    f.handle(function (v) {
      asserts.assert(4 == v);
      calls++;
    });
    
    t.trigger(4);
    
    asserts.assert(1 == calls);
    return asserts.done();
  }
  
  public function testFlatten() {
    var f = Future.sync(Future.sync(4));
    var flat = Future.flatten(f),
      calls = 0;
      
    flat.handle(function (v) {
      asserts.assert(4 == v);
      calls++;
    });
    
    asserts.assert(1 == calls);
    return asserts.done();
  }
  
  public function testOps() {
    var t1 = Future.trigger(),
      t2 = Future.trigger();
    var f1:Future<Int> = t1,
      f2:Future<Int> = t2;
      
    var f = f1 || f2;
    t1.trigger(1);
    t2.trigger(2);
    f.handle(function(v) asserts.assert(v == 1));
    var f = f1 && f2;
    f.handle(function (p) {
      asserts.assert(p.a == 1);  
      asserts.assert(p.b == 2);  
    });
    return asserts.done();
  }
  
  public function testMany() {
    var triggers = [for (i in 0...10) Future.trigger()];
    var futures = [for (t in triggers) t.asFuture()];
    
    var read1 = false,
      read2 = false;
    
    var lazy1 = Future.lazy(function () {
      read1 = true;
      return 10;
    });
    
    var lazy2 = Future.lazy(function () {
      read2 = true;
      return 10;
    });
    
    futures.unshift(lazy1);
    futures.push(lazy2);
    
    function sum(a:Array<Int>, ?index = 0)
      return 
        if (index < a.length) a[index] + sum(a, index + 1);
        else 0;
    
    var f = Future.ofMany(futures).map(sum.bind(_, 0)),
      f2 = Future.ofMany(futures, false).map(sum.bind(_, 0));
      
    asserts.assert(!read1);
    asserts.assert(!read2);
    
    f.handle(function(v) asserts.assert(v == 65));
    f2.handle(function(v) asserts.assert(v == 65));
    
    var handled = false;
    f.handle(function () handled = true);
    
    asserts.assert(!handled);
    asserts.assert(read1);
    asserts.assert(!read2);
    
    for (i in 0...triggers.length)
      triggers[i].trigger(i);
      
    asserts.assert(handled);
    return asserts.done();
  }
  
  public function testNever() {
    var f:Future<Int> = cast Future.NEVER; 
    f.handle(function () {}).dissolve();
    function foo<A>() {
      var f:Future<A> = cast Future.NEVER; 
      f.handle(function () {}).dissolve();  
    }
    foo();
    return asserts.done();
  }

  public function testFuturistic() {
    var f:Futuristic<Int> = 12;
    f.map(function (v) return v * 2).handle(function (v) asserts.assert(24 == v));
    return asserts.done();
  }
}