do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'dma_admin') then
    create role dma_admin with login superuser createdb createrole password 'dmapw_admin';
  else
    alter role dma_admin with login superuser createdb createrole password 'dmapw_admin';
  end if;

  if not exists (select 1 from pg_roles where rolname = 'dma_user') then
    create role dma_user with login password 'dmapw_user';
  else
    alter role dma_user with login password 'dmapw_user';
  end if;
end
$$;

alter database "lDungeonMasterAgent" owner to dma_user;

grant connect on database "lDungeonMasterAgent" to dma_user;
grant usage, create on schema public to dma_user;
grant all privileges on all tables in schema public to dma_user;
grant all privileges on all sequences in schema public to dma_user;
grant all privileges on all functions in schema public to dma_user;

alter default privileges in schema public grant all privileges on tables to dma_user;
alter default privileges in schema public grant all privileges on sequences to dma_user;
alter default privileges in schema public grant all privileges on functions to dma_user;

alter table if exists modules owner to dma_user;
alter table if exists acts owner to dma_user;
alter table if exists scenes owner to dma_user;
alter table if exists act_narratives owner to dma_user;
alter table if exists scene_narratives owner to dma_user;
alter table if exists narrative_images owner to dma_user;
alter table if exists player_characters owner to dma_user;
alter table if exists npcs owner to dma_user;
alter table if exists locations owner to dma_user;
alter table if exists items owner to dma_user;
alter table if exists handouts owner to dma_user;
alter table if exists encounters owner to dma_user;
alter table if exists scene_assets owner to dma_user;

alter sequence if exists modules_id_seq owner to dma_user;
alter sequence if exists acts_id_seq owner to dma_user;
alter sequence if exists scenes_id_seq owner to dma_user;
alter sequence if exists act_narratives_id_seq owner to dma_user;
alter sequence if exists scene_narratives_id_seq owner to dma_user;
alter sequence if exists narrative_images_id_seq owner to dma_user;
alter sequence if exists player_characters_id_seq owner to dma_user;
alter sequence if exists npcs_id_seq owner to dma_user;
alter sequence if exists locations_id_seq owner to dma_user;
alter sequence if exists items_id_seq owner to dma_user;
alter sequence if exists handouts_id_seq owner to dma_user;
alter sequence if exists encounters_id_seq owner to dma_user;
alter sequence if exists scene_assets_id_seq owner to dma_user;
