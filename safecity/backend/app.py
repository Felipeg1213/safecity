from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime, timedelta
import math

app = Flask(__name__)
CORS(app)

# En producción usar Redis o PostgreSQL con PostGIS
active_users: dict = {}  # { user_id: {lat, lng, timestamp} }


def haversine_km(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    """Distancia en km entre dos coordenadas geográficas."""
    R = 6371
    d_lat = math.radians(lat2 - lat1)
    d_lng = math.radians(lng2 - lng1)
    a = (math.sin(d_lat / 2) ** 2 +
         math.cos(math.radians(lat1)) *
         math.cos(math.radians(lat2)) *
         math.sin(d_lng / 2) ** 2)
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


def density_level(count: int) -> str:
    if count > 100: return 'critical'
    if count > 50:  return 'high'
    if count > 20:  return 'medium'
    return 'low'


def purge_stale_users(minutes: int = 5):
    """Elimina pings con más de N minutos de antigüedad."""
    cutoff = datetime.utcnow() - timedelta(minutes=minutes)
    stale = [
        uid for uid, u in active_users.items()
        if datetime.fromisoformat(u['timestamp']) < cutoff
    ]
    for uid in stale:
        del active_users[uid]


# ─── ENDPOINTS ───────────────────────────────────────────────────────────────

@app.route('/ping', methods=['POST'])
def ping():
    """Registra la ubicación activa de un usuario."""
    data = request.get_json(silent=True)
    if not data:
        return jsonify({'error': 'Body JSON requerido'}), 400

    user_id = data.get('user_id')
    lat     = data.get('lat')
    lng     = data.get('lng')

    if not all([user_id, lat is not None, lng is not None]):
        return jsonify({'error': 'Faltan parámetros: user_id, lat, lng'}), 400

    active_users[user_id] = {
        'lat': float(lat),
        'lng': float(lng),
        'timestamp': datetime.utcnow().isoformat(),
    }
    return jsonify({'status': 'ok', 'users_online': len(active_users)}), 200


@app.route('/density', methods=['GET'])
def get_density():
    """Retorna la densidad de usuarios en un radio dado."""
    try:
        lat    = float(request.args.get('lat', 0))
        lng    = float(request.args.get('lng', 0))
        radius = float(request.args.get('radius', 0.5))  # km
    except (ValueError, TypeError):
        return jsonify({'error': 'Parámetros inválidos'}), 400

    purge_stale_users()

    nearby = [
        u for u in active_users.values()
        if haversine_km(lat, lng, u['lat'], u['lng']) <= radius
    ]

    return jsonify({
        'count':       len(nearby),
        'level':       density_level(len(nearby)),
        'radius_km':   radius,
        'coordinates': {'lat': lat, 'lng': lng},
    }), 200


@app.route('/density/heatmap', methods=['GET'])
def get_heatmap():
    """Retorna todos los usuarios activos como puntos de calor."""
    purge_stale_users()
    points = [
        {'lat': u['lat'], 'lng': u['lng']}
        for u in active_users.values()
    ]
    return jsonify({'points': points, 'total': len(points)}), 200


@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'ok',
        'users_online': len(active_users),
        'timestamp': datetime.utcnow().isoformat(),
    }), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
