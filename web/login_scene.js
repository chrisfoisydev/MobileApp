// Login backdrop: a continuous journey along Puget Sound toward Seattle.
// Mount Rainier sits hazy on the horizon, the Space Needle and downtown
// towers wait at the end of the water, and an evergreen forest streams
// past on both sides while a ferry crosses. three.js renders it; GSAP
// drives the misty reveal on entry and the pointer parallax.
// Invoked from Flutter via window.initLoginScene(container).
(function () {
  'use strict';

  window.initLoginScene = function (container) {
    if (!window.THREE || !window.gsap) return;
    var attempts = 0;
    (function start() {
      var w = container.clientWidth;
      var h = container.clientHeight;
      if ((!w || !h) && attempts++ < 300) {
        requestAnimationFrame(start);
        return;
      }
      if (w && h) build(container, w, h);
    })();
  };

  function mat(color, opts) {
    opts = opts || {};
    return new THREE.MeshStandardMaterial({
      color: color,
      roughness: opts.rough == null ? 0.85 : opts.rough,
      metalness: opts.metal == null ? 0.0 : opts.metal,
      flatShading: !!opts.flat,
      transparent: opts.opacity != null,
      opacity: opts.opacity == null ? 1 : opts.opacity
    });
  }

  // A classic stacked-cone evergreen with a short trunk.
  function makeEvergreen() {
    var g = new THREE.Group();
    var green = mat(Math.random() < 0.5 ? 0x2f6b4e : 0x387c5b, { flat: true, rough: 0.95 });
    var trunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.12, 0.16, 0.7, 6), mat(0x6b4f3a, { flat: true }));
    trunk.position.y = 0.35;
    g.add(trunk);
    var tiers = 3;
    for (var i = 0; i < tiers; i++) {
      var r = 1.05 - i * 0.28;
      var hh = 1.25;
      var cone = new THREE.Mesh(new THREE.ConeGeometry(r, hh, 7), green);
      cone.position.y = 0.7 + i * 0.85 + hh * 0.5 - 0.2;
      g.add(cone);
    }
    return g;
  }

  // Simplified but recognizable Space Needle: tapered stem, flying-saucer
  // tophouse, roof and spire with a small BECU-red beacon at the tip.
  function makeSpaceNeedle() {
    var g = new THREE.Group();
    var steel = mat(0xd2dce1, { rough: 0.5, metal: 0.25, flat: true });
    var stem = new THREE.Mesh(new THREE.CylinderGeometry(0.5, 1.5, 11, 12), steel);
    stem.position.y = 5.5;
    g.add(stem);
    var underside = new THREE.Mesh(new THREE.ConeGeometry(2.6, 1.6, 16), steel);
    underside.position.y = 10.6;
    underside.rotation.x = Math.PI;
    g.add(underside);
    var saucer = new THREE.Mesh(
      new THREE.CylinderGeometry(2.5, 2.5, 0.7, 24),
      mat(0xe9eef0, { rough: 0.4, metal: 0.2 }));
    saucer.position.y = 11.4;
    g.add(saucer);
    var roof = new THREE.Mesh(new THREE.ConeGeometry(2.2, 1.1, 24),
      mat(0x6fae9e, { rough: 0.5 }));
    roof.position.y = 12.2;
    g.add(roof);
    var spire = new THREE.Mesh(new THREE.CylinderGeometry(0.05, 0.12, 2.4, 6), steel);
    spire.position.y = 13.7;
    g.add(spire);
    var beacon = new THREE.Mesh(new THREE.SphereGeometry(0.18, 12, 12),
      new THREE.MeshStandardMaterial({
        color: 0xd62b2f, emissive: 0x7a1518, roughness: 0.4
      }));
    beacon.position.y = 15;
    g.add(beacon);
    return g;
  }

  function build(container, width, height) {
    container.style.background =
      'linear-gradient(180deg,#eaf4f8 0%,#dceaef 45%,#eef6f8 100%)';
    container.style.overflow = 'hidden';

    var scene = new THREE.Scene();
    var FOG = 0xe7f1f5;
    // Very light haze far in the distance only, so Seattle and the
    // mountains read clearly.
    scene.fog = new THREE.Fog(FOG, 80, 300);

    var camera = new THREE.PerspectiveCamera(48, width / height, 0.1, 320);
    camera.position.set(0, 3.6, 15);
    // Aim a little higher so the skyline and Mount Rainier fill more of
    // the view.
    camera.lookAt(0, 8, -45);

    var renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    renderer.setSize(width, height);
    container.appendChild(renderer.domElement);

    scene.add(new THREE.HemisphereLight(0xffffff, 0xc9ddd6, 1.0));
    var sun = new THREE.DirectionalLight(0xfff4e6, 0.8);
    sun.position.set(-6, 10, -2);
    scene.add(sun);

    // --- Distant landmarks (far group: slow pointer parallax only) ---
    var far = new THREE.Group();
    scene.add(far);

    // Mount Rainier — a large snow-capped peak towering behind downtown.
    var rainier = new THREE.Group();
    var base = new THREE.Mesh(new THREE.ConeGeometry(30, 30, 32),
      mat(0xa7c1d0, { rough: 1, flat: true }));
    base.position.y = 15;
    rainier.add(base);
    var snow = new THREE.Mesh(new THREE.ConeGeometry(11, 11, 32),
      mat(0xfbfdff, { rough: 1, flat: true }));
    snow.position.y = 24.5;
    rainier.add(snow);
    rainier.position.set(9, 0, -86);
    far.add(rainier);

    // A second softer peak (the Olympics) low on the left.
    var peak = new THREE.Mesh(new THREE.ConeGeometry(18, 10, 24),
      mat(0xbcd0da, { rough: 1, flat: true, opacity: 0.92 }));
    peak.position.set(-17, 5, -90);
    far.add(peak);

    // Downtown skyline: a cluster of towers at the end of the water.
    var skyline = new THREE.Group();
    var towerCols = [0x4a6577, 0x577080, 0x536d7e, 0x415a6b, 0x5d7585];
    var defs = [
      [-7, 9, 1.6], [-5, 13, 1.8], [-3.2, 18, 1.7], [-1.2, 24, 2.0],
      [0.8, 16, 1.7], [2.6, 21, 1.9], [4.4, 12, 1.7], [6.2, 15, 1.6],
      [8, 10, 1.5]
    ];
    for (var i = 0; i < defs.length; i++) {
      var d = defs[i];
      var col = towerCols[i % towerCols.length];
      var b = new THREE.Mesh(
        new THREE.BoxGeometry(d[2], d[1], d[2]),
        mat(col, { rough: 0.7, metal: 0.1, opacity: 0.96 }));
      b.position.set(d[0], d[1] / 2, -2 + (i % 3) * -1.5);
      skyline.add(b);
    }
    skyline.position.set(-2, 0, -56);
    far.add(skyline);

    // Space Needle, just left of downtown.
    var needle = makeSpaceNeedle();
    needle.position.set(-12, 0, -52);
    far.add(needle);

    // --- The journey lane (streams toward the camera) ---
    var land = new THREE.Mesh(new THREE.PlaneGeometry(220, 200),
      mat(0xbcd6bf, { rough: 1 }));
    land.rotation.x = -Math.PI / 2;
    land.position.set(0, 0, -40);
    scene.add(land);

    var water = new THREE.Mesh(new THREE.PlaneGeometry(13, 200),
      mat(0x8fc4d6, { rough: 0.25, metal: 0.35, opacity: 0.92 }));
    water.rotation.x = -Math.PI / 2;
    water.position.set(0, 0.05, -40);
    scene.add(water);

    var travel = new THREE.Group();
    scene.add(travel);

    var START_Z = -78, END_Z = 18, SPAN = END_Z - START_Z;
    var streamers = [];

    function placeTree(t, fresh) {
      var side = Math.random() < 0.5 ? -1 : 1;
      // Keep trees off the central water channel.
      t.position.x = side * (7.5 + Math.random() * 13);
      t.position.z = fresh ? (START_Z + Math.random() * SPAN) : START_Z + Math.random() * 4;
      var s = 0.8 + Math.random() * 1.4;
      t.scale.set(s, s, s);
      t.rotation.y = Math.random() * Math.PI;
    }
    for (var k = 0; k < 60; k++) {
      var tree = makeEvergreen();
      placeTree(tree, true);
      tree.userData.speed = 1; // all move together
      travel.add(tree);
      streamers.push(tree);
    }

    // Drifting mist patches low over the water for depth and motion.
    var mistMat = new THREE.MeshBasicMaterial({
      color: 0xffffff, transparent: true, opacity: 0.16, depthWrite: false
    });
    var mists = [];
    for (var m = 0; m < 10; m++) {
      var mist = new THREE.Mesh(new THREE.PlaneGeometry(14, 5), mistMat);
      mist.rotation.x = -Math.PI / 2.1;
      mist.position.set((Math.random() - 0.5) * 18, 0.6 + Math.random() * 1.6,
        START_Z + Math.random() * SPAN);
      travel.add(mist);
      mists.push(mist);
    }

    // A Washington State ferry crossing the channel ahead.
    var ferry = new THREE.Group();
    var hull = new THREE.Mesh(new THREE.BoxGeometry(3.4, 0.7, 1.3),
      mat(0xf4f6f7, { rough: 0.6 }));
    var deck = new THREE.Mesh(new THREE.BoxGeometry(2.4, 0.6, 1.1),
      mat(0xeef1f2, { rough: 0.6 }));
    deck.position.y = 0.62;
    var stripe = new THREE.Mesh(new THREE.BoxGeometry(3.42, 0.18, 1.32),
      mat(0x2f6b4e, { rough: 0.6 }));
    stripe.position.y = 0.28;
    ferry.add(hull, deck, stripe);
    ferry.position.set(-6, 0.45, -34);
    ferry.scale.set(1.1, 1.1, 1.1);
    scene.add(ferry);

    // Soft clouds drifting high.
    var clouds = new THREE.Group();
    for (var c = 0; c < 6; c++) {
      var cloud = new THREE.Mesh(new THREE.SphereGeometry(3 + Math.random() * 2, 10, 8),
        new THREE.MeshBasicMaterial({ color: 0xffffff, transparent: true, opacity: 0.5 }));
      cloud.position.set((Math.random() - 0.5) * 60, 20 + Math.random() * 8,
        -50 - Math.random() * 25);
      cloud.scale.y = 0.5;
      clouds.add(cloud);
    }
    scene.add(clouds);

    // --- Motion: forward travel + ambient drift ---
    var clock = new THREE.Clock();
    var SPEED = 9;
    var ferryDir = 1;

    gsap.ticker.add(function () {
      var dt = Math.min(clock.getDelta(), 0.05);
      var t = clock.elapsedTime;

      for (var i = 0; i < streamers.length; i++) {
        var s = streamers[i];
        s.position.z += SPEED * dt;
        if (s.position.z > END_Z) {
          s.position.z -= SPAN;
          placeTree(s, false);
        }
      }
      for (var j = 0; j < mists.length; j++) {
        var mi = mists[j];
        mi.position.z += SPEED * 0.7 * dt;
        if (mi.position.z > END_Z) mi.position.z -= SPAN;
      }

      // Ferry glides across the channel and turns back.
      ferry.position.x += ferryDir * 0.6 * dt;
      if (ferry.position.x > 5) ferryDir = -1;
      if (ferry.position.x < -5) ferryDir = 1;
      ferry.rotation.y = ferryDir > 0 ? -Math.PI / 2 : Math.PI / 2;
      ferry.position.y = 0.45 + Math.sin(t * 1.5) * 0.05;

      clouds.position.x = Math.sin(t * 0.04) * 6;

      // Gentle traveling bob on the camera.
      camera.position.y = 3.6 + Math.sin(t * 0.8) * 0.12;

      renderer.render(scene, camera);
    });

    // --- Entrance: the city emerges from the mist as we glide in ---
    var tl = gsap.timeline();
    tl.from(scene.fog, { far: 120, duration: 2.6, ease: 'power2.out' }, 0);
    tl.from(camera.position, { y: 9, z: 24, duration: 2.8, ease: 'power3.out' }, 0);
    tl.from(far.position, { y: -4, duration: 2.6, ease: 'power2.out' }, 0);
    needle.scale.set(0.001, 0.001, 0.001);
    tl.to(needle.scale, { x: 1, y: 1, z: 1, duration: 1.6, ease: 'back.out(1.6)' }, 0.8);

    // --- Pointer parallax: lean the world as you move ---
    var camX = gsap.quickTo(camera.position, 'x', { duration: 1.1, ease: 'power2.out' });
    var farRot = gsap.quickTo(far.rotation, 'y', { duration: 1.1, ease: 'power2.out' });
    window.addEventListener('pointermove', function (e) {
      var nx = e.clientX / window.innerWidth - 0.5;
      camX(nx * 3.2);
      farRot(nx * -0.08);
    });

    if (window.ResizeObserver) {
      new ResizeObserver(function () {
        var w = container.clientWidth;
        var h = container.clientHeight;
        if (!w || !h) return;
        camera.aspect = w / h;
        camera.updateProjectionMatrix();
        renderer.setSize(w, h);
      }).observe(container);
    }
  }
})();
