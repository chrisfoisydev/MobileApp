// 3D login backdrop: floating BECU-colored shapes rendered with three.js,
// choreographed with GSAP (elastic entrance, perpetual float, pointer
// parallax). Invoked from Flutter via window.initLoginScene(container).
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

  function build(container, width, height) {
    container.style.background =
      'linear-gradient(180deg,#f7fafc 0%,#e3eff2 60%,#f2f7f9 100%)';
    container.style.overflow = 'hidden';

    var scene = new THREE.Scene();
    var camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 100);
    camera.position.set(0, 0.3, 9);

    var renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    renderer.setSize(width, height);
    container.appendChild(renderer.domElement);

    scene.add(new THREE.HemisphereLight(0xffffff, 0xd8e6ec, 0.95));
    var key = new THREE.DirectionalLight(0xffffff, 0.85);
    key.position.set(4, 6, 6);
    scene.add(key);
    var rim = new THREE.DirectionalLight(0x7ee2eb, 0.45);
    rim.position.set(-5, -2, -4);
    scene.add(rim);

    var group = new THREE.Group();
    scene.add(group);

    function mat(color, rough, metal) {
      return new THREE.MeshStandardMaterial({
        color: color, roughness: rough, metalness: metal
      });
    }
    var red = mat(0xd62b2f, 0.32, 0.18);
    var teal = mat(0x007c89, 0.28, 0.22);
    var navy = mat(0x14304a, 0.42, 0.12);
    var white = mat(0xffffff, 0.18, 0.05);

    var meshes = [];
    function add(geo, material, x, y, z, s) {
      var m = new THREE.Mesh(geo, material);
      m.position.set(x, y, z);
      m.userData.s = s;
      m.scale.set(0.001, 0.001, 0.001);
      group.add(m);
      meshes.push(m);
      return m;
    }

    // Hero "coin" plus an orbiting cast of shapes.
    var coin = add(new THREE.CylinderGeometry(1, 1, 0.16, 56), red, 0, 0.5, 0, 1.5);
    coin.rotation.set(Math.PI / 2.25, 0, -0.25);
    add(new THREE.TorusGeometry(0.85, 0.26, 24, 64), teal, -2.7, 1.7, -1.6, 1);
    add(new THREE.IcosahedronGeometry(0.6, 0), navy, 2.8, 1.9, -1.2, 1);
    add(new THREE.SphereGeometry(0.45, 32, 32), white, -2.3, -1.2, -0.4, 1);
    add(new THREE.IcosahedronGeometry(0.34, 0), teal, 2.4, -1.0, 0.5, 1);
    add(new THREE.TorusKnotGeometry(0.4, 0.13, 110, 16), red, -3.2, 0.2, -2.2, 0.9);
    add(new THREE.SphereGeometry(0.2, 24, 24), red, 1.7, 1.0, 1.2, 1);
    add(new THREE.SphereGeometry(0.13, 24, 24), teal, -1.4, 2.0, 0.7, 1);
    add(new THREE.TorusGeometry(0.3, 0.1, 18, 48), white, 3.3, 0.3, -0.2, 1);

    // Drifting dust for depth.
    var N = 110;
    var positions = new Float32Array(N * 3);
    for (var i = 0; i < N; i++) {
      positions[i * 3] = (Math.random() - 0.5) * 14;
      positions[i * 3 + 1] = (Math.random() - 0.5) * 9;
      positions[i * 3 + 2] = -3 - Math.random() * 4;
    }
    var pGeo = new THREE.BufferGeometry();
    pGeo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    var points = new THREE.Points(pGeo, new THREE.PointsMaterial({
      color: 0x9fb9c4, size: 0.05, transparent: true, opacity: 0.7
    }));
    scene.add(points);

    // Entrance: shapes pop in with an elastic stagger while the camera
    // dollies forward.
    var tl = gsap.timeline({
      defaults: { ease: 'elastic.out(1, 0.55)', duration: 1.6 }
    });
    meshes.forEach(function (m, i) {
      tl.to(m.scale, {
        x: m.userData.s, y: m.userData.s, z: m.userData.s
      }, 0.15 + i * 0.12);
    });
    tl.from(camera.position, { z: 15, duration: 2.2, ease: 'power3.out' }, 0);

    // Perpetual motion: gentle bobbing and slow tumbling per shape.
    meshes.forEach(function (m) {
      gsap.to(m.position, {
        y: '+=' + (0.22 + Math.random() * 0.3),
        duration: 2.2 + Math.random() * 1.8,
        yoyo: true, repeat: -1, ease: 'sine.inOut',
        delay: Math.random()
      });
      gsap.to(m.rotation, {
        x: '+=' + (0.6 + Math.random() * 1.4),
        y: '+=' + (1.0 + Math.random() * 2.0),
        duration: 9 + Math.random() * 7,
        repeat: -1, ease: 'none'
      });
    });
    gsap.to(points.rotation, { z: 0.4, duration: 60, repeat: -1, yoyo: true, ease: 'none' });

    // Pointer parallax on the whole cluster.
    var qx = gsap.quickTo(group.rotation, 'y', { duration: 0.9, ease: 'power2.out' });
    var qy = gsap.quickTo(group.rotation, 'x', { duration: 0.9, ease: 'power2.out' });
    window.addEventListener('pointermove', function (e) {
      qx((e.clientX / window.innerWidth - 0.5) * 0.55);
      qy((e.clientY / window.innerHeight - 0.5) * 0.3);
    });

    gsap.ticker.add(function () {
      renderer.render(scene, camera);
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
