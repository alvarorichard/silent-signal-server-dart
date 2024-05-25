// ignore_for_file: constant_identifier_names

const FETCH_GROUPS = '''
  SELECT
    g.id,
    g.group_name,
    g.description,
    g.picture,
    (SELECT JSON_AGG(JSON_BUILD_OBJECT(
      'name',
      c.username,
      'picture',
      c.picture,
    ))
    FROM users c
    WHERE c.id = g.creator_id) AS creator,
    g.created_at
  FROM groups g
''';

const FETCH_GROUP_BY_NAME = r'''
  SELECT
    g.id,
    g.group_name,
    g.description,
    g.picture,
    (SELECT JSON_AGG(JSON_BUILD_OBJECT(
      'name',
      c.username,
      'picture',
      c.picture,
    ))
    FROM users c
    WHERE c.id = g.creator_id) AS creator,
    g.created_at
  FROM groups g
  WHERE g.group_name = $1
''';

const CREATE_GROUP = r'''
  INSERT INTO groups(
    group_name,
    description,
    creator_id
  ) VALUES ($1, $2, $3)
''';

const UPDATE_GROUP = '''
  UPDATE groups SET
    group_name = @group_name,
    description = @description,
    picture = @picture
  WHERE id = @id AND creator_id = @creator_id
''';

const DELETE_GROUP = r'DELETE FROM groups WHERE group_name = $1';
