from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI(title="Music App API")

# 允许 Flutter 调用
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class MusicAccountCreate(BaseModel):
    platform: str
    name: str
    avatarUrl: Optional[str] = ""


class MusicAccount(BaseModel):
    id: str
    platform: str
    name: str
    avatarUrl: Optional[str] = ""


class Playlist(BaseModel):
    id: str
    accountId: str
    platform: str
    name: str
    coverUrl: Optional[str] = ""
    trackCount: int = 0


class LoadingConfig(BaseModel):
    enable: bool
    image: str
    text: str


class AnnouncementConfig(BaseModel):
    enable: bool
    content: str


class SearchSong(BaseModel):
    id: str
    platform: str
    title: str
    artist: str
    duration: int
    quality: List[str] = []


class SongResource(BaseModel):
    songId: str
    platform: str
    quality: str
    url: str


accounts_db: List[MusicAccount] = [
    MusicAccount(
        id="qq_1",
        platform="qq",
        name="QQ音乐账号",
        avatarUrl=""
    ),
    MusicAccount(
        id="netease_1",
        platform="netease",
        name="网易云账号",
        avatarUrl=""
    ),
]

playlists_db: List[Playlist] = [
    Playlist(
        id="qq_p1",
        accountId="qq_1",
        platform="qq",
        name="我喜欢的歌",
        coverUrl="",
        trackCount=52
    ),
    Playlist(
        id="qq_p2",
        accountId="qq_1",
        platform="qq",
        name="学习歌单",
        coverUrl="",
        trackCount=31
    ),
    Playlist(
        id="netease_p1",
        accountId="netease_1",
        platform="netease",
        name="深夜循环",
        coverUrl="",
        trackCount=18
    ),
]

search_songs_db: List[SearchSong] = [
    SearchSong(
        id="qq_song_1",
        platform="qq",
        title="夜曲",
        artist="周杰伦",
        duration=245,
        quality=["standard", "hq", "sq"]
    ),
    SearchSong(
        id="qq_song_2",
        platform="qq",
        title="晴天",
        artist="周杰伦",
        duration=269,
        quality=["standard", "hq"]
    ),
    SearchSong(
        id="netease_song_1",
        platform="netease",
        title="起风了",
        artist="买辣椒也用券",
        duration=311,
        quality=["standard", "hq", "sq"]
    ),
    SearchSong(
        id="netease_song_2",
        platform="netease",
        title="123木头人",
        artist="黑涩会美眉",
        duration=198,
        quality=["standard"]
    ),
]

remote_config = {
    "loading": LoadingConfig(
        enable=True,
        image="assets/images/loading.jpg",
        text="远程加载中..."
    ),
    "announcement": AnnouncementConfig(
        enable=True,
        content="这是远程公告，可以随时改，不用重新发版"
    )
}


@app.get("/health")
def health():
    return {
        "code": 0,
        "message": "ok",
        "data": {"status": "up"}
    }


@app.get("/accounts")
def get_accounts():
    return {
        "code": 0,
        "message": "success",
        "data": [item.model_dump() for item in accounts_db]
    }


@app.post("/accounts")
def create_account(payload: MusicAccountCreate):
    account_id = f"{payload.platform}_{len(accounts_db) + 1}"
    account = MusicAccount(
        id=account_id,
        platform=payload.platform,
        name=payload.name,
        avatarUrl=payload.avatarUrl or ""
    )
    accounts_db.append(account)
    return {
        "code": 0,
        "message": "success",
        "data": account.model_dump()
    }


@app.delete("/accounts/{account_id}")
def delete_account(account_id: str):
    global accounts_db, playlists_db

    target = next((item for item in accounts_db if item.id == account_id), None)
    if target is None:
        raise HTTPException(status_code=404, detail="account not found")

    accounts_db = [item for item in accounts_db if item.id != account_id]
    playlists_db = [item for item in playlists_db if item.accountId != account_id]

    return {
        "code": 0,
        "message": "success",
        "data": True
    }


@app.get("/playlists")
def get_playlists(account_id: str = Query(...)):
    items = [item.model_dump() for item in playlists_db if item.accountId == account_id]
    return {
        "code": 0,
        "message": "success",
        "data": items
    }


@app.get("/config")
def get_config():
    return {
        "code": 0,
        "message": "success",
        "data": {
            "loading": remote_config["loading"].model_dump(),
            "announcement": remote_config["announcement"].model_dump()
        }
    }


@app.get("/search")
def search_songs(
    keyword: str = Query(...),
    platform: Optional[str] = Query(None),
    page: int = Query(1),
    page_size: int = Query(20),
):
    normalized = keyword.strip().lower()

    filtered = []
    for item in search_songs_db:
        if platform and platform not in ["defaultPlatform", item.platform]:
            continue

        if (
            normalized in item.title.lower()
            or normalized in item.artist.lower()
            or normalized in item.id.lower()
        ):
            filtered.append(item.model_dump())

    start = max((page - 1) * page_size, 0)
    end = start + page_size
    paged = filtered[start:end]

    return {
        "code": 0,
        "message": "success",
        "data": paged
    }


@app.get("/song/resource")
def get_song_resource(
    song_id: str = Query(...),
    platform: str = Query(...),
    quality: str = Query("standard"),
):
    target = next(
        (
            item for item in search_songs_db
            if item.id == song_id and item.platform == platform
        ),
        None
    )

    if target is None:
        raise HTTPException(status_code=404, detail="song not found")

    if quality not in target.quality:
        quality = "standard"

    return {
        "code": 0,
        "message": "success",
        "data": SongResource(
            songId=song_id,
            platform=platform,
            quality=quality,
            url="https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
        ).model_dump()
    }

